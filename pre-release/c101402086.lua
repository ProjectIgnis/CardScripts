--JP name
--Archidux, the Squid Sorcerer
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 WATER monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),2)
	--You can send 1 card you control to the GY; all WATER monsters you control gain 500 ATK/DEF this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.atkdefcost)
	e1:SetOperation(s.atkdefop)
	c:RegisterEffect(e1)
	--If a WATER Link Monster(s) you control is destroyed by an opponent's card effect, while this card is in your GY (except during the Damage Step): You can banish this card, then target 1 of those destroyed monsters; Special Summon 1 WATER monster from your hand or GY, with a Level less than or equal to that monster's Link Rating
	local g=Group.CreateGroup()
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetLabelObject(g)
	c:RegisterEffect(e2)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if Duel.IsDamageStep() or eg:IsContains(c) then return end
		local tg=eg:Filter(s.tgfilter,nil,e,tp,1-tp,true)
		if #tg>0 then
			for tc in tg:Iter() do
				tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
			end
			if Duel.GetCurrentChain()==0 then g:Clear() end
			g:Merge(tg)
			g:Remove(function(c) return not c:HasFlagEffect(id) end,nil)
			Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
		end
	end)
	c:RegisterEffect(e3)
end
function s.atkdefcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.atkdefop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2))
	--All WATER monsters you control gain 500 ATK/DEF this turn
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetTargetRange(LOCATION_MZONE,0)
	e1a:SetTarget(function(e,c)
		return c:IsAttribute(ATTRIBUTE_WATER)
	end)
	e1a:SetValue(500)
	e1a:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1a,tp)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	Duel.RegisterEffect(e1b,tp)
end
function s.tgfilter(c,e,tp,opp,ign_chk)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsPreviousAttributeOnField(ATTRIBUTE_WATER)
		and c:IsLinkMonster() and c:IsFaceup() and c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and c:IsCanBeEffectTarget(e)
		and c:IsReason(REASON_EFFECT) and c:IsReasonPlayer(opp)
		and (ign_chk or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp,c:GetLink()))
end
function s.spfilter(c,e,tp,link)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelBelow(link) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local opp=1-tp
	local g=e:GetLabelObject():Filter(s.tgfilter,nil,e,tp,opp)
	if chkc then return g:IsContains(chkc) and s.tgfilter(chkc,e,tp,opp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	local tc=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetLink())
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end