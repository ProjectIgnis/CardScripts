--魂への引導
--Final Journey of the Soul
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent activates a card or effect that includes an effect that Special Summons a Monster Card(s) from the GY: Negate that effect, and if you do, Special Summon 1 monster from your opponent's GY to their field, then send any number of face-up monsters they control to the GY whose total ATK equal 6000 or less
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If this card is banished: You can add it to your hand, then immediately after this effect resolves, you can Normal Summon 1 monster from your hand that requires 1 or more Tributes without Tributing
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ex1,g1,gc1,dp1,loc1=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	local ex2,g2,gc2,dp2,loc2=Duel.GetPossibleOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	if not (ex1 or ex2) then return false end
	local g=Group.CreateGroup()
	if g1 then g:Merge(g1) end
	if g2 then g:Merge(g2) end
	return (((loc1 or 0)|(loc2 or 0))&LOCATION_GRAVE)>0 or (#g>0 and g:IsExists(function(c) return c:IsLocation(LOCATION_GRAVE) and c:IsMonster() end,1,nil))
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_MZONE)
end
function s.rescon(sg,e,tp,mg)
	local atk_total=sg:GetSum(Card.GetAttack)
	return atk_total<=6000,atk_total>6000
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
		if #sg>0 and Duel.SpecialSummon(sg,0,tp,1-tp,false,false,POS_FACEUP)>0 then
			local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttackBelow,6000),tp,0,LOCATION_MZONE,nil)
			if #g==0 then return end
			local gg=aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon,1,tp,HINTMSG_TOGRAVE)
			if #gg>0 then
				Duel.HintSelection(gg)
				Duel.BreakEffect()
				Duel.SendtoGrave(gg,REASON_EFFECT)
			end
		end
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.sumfilter(c,handler)
	if not c:IsSummonableCard() then return false end
	local min_req,max_req=c:GetTributeRequirement()
	if min_req>=1 or max_req>=1 then
		--Normal Summon 1 monster from your hand that requires 1 or more Tributes without Tributing
		local e1=Effect.CreateEffect(handler)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
		e1:SetCondition(function(e,c,minc)
			return c==nil or Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
		local res=c:IsSummonable(true,nil)
		e1:Reset()
		return res
	end
	return false
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND) then
		Duel.ShuffleHand(tp)
		local g=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND,0,nil,c)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sc=g:Select(tp,1,1,nil):GetFirst()
			if sc then
				--Normal Summon 1 monster from your hand that requires 1 or more Tributes without Tributing
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(aux.Stringid(id,3))
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
				e1:SetCondition(function(e,c,minc)
					return c==nil or Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
				end)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				sc:RegisterEffect(e1)
				Duel.BreakEffect()
				Duel.Summon(tp,sc,true,nil)
			end
		end
	end
end