--王の記憶－オベリスクの巨神兵
--Obelisk the Tormentor, the Pharaoh's Memory
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustBeSpecialSummoned()
	--When you draw this card, or an opponent's monster declares a direct attack: You can reveal this card in your hand; Special Summon from your GY as many monsters destroyed this turn as possible, then Tribute as many monsters you control as possible, and if you do, Special Summon this card, then if you Tributed 3 or more monsters, destroy as many monsters your opponent controls as possible, and if you do, halve your opponent's LP. You can only use this effect of "Obelisk the Tormentor, the Pharaoh's Memory" once per Duel
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE+CATEGORY_DESTROY)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetCode(EVENT_DRAW)
	e1a:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1a:SetCost(Cost.SelfReveal)
	e1a:SetTarget(s.sptg)
	e1a:SetOperation(s.spop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1b:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1b:SetRange(LOCATION_HAND)
	e1b:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetAttacker():IsControler(1-tp) and not Duel.GetAttackTarget()
	end)
	c:RegisterEffect(e1b)
end
function s.gyspfilter(c,e,tp,turn_count)
	return c:IsReason(REASON_DESTROY) and c:GetTurnID()==turn_count and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.gyspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,Duel.GetTurnCount())
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and Duel.IsPlayerCanRelease(tp) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local summon_count=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if summon_count<=0 then return end
	local g=Duel.GetMatchingGroup(s.gyspfilter,tp,LOCATION_GRAVE,0,nil,e,tp,Duel.GetTurnCount())
	if #g==0 then return end
	summon_count=math.min(summon_count,#g)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then summon_count=1 end
	local sg=nil
	if summon_count<#g then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		sg=g:Select(tp,summon_count,summon_count,nil)
	else
		sg=g
	end
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local rg=Duel.GetMatchingGroup(Card.IsReleasableByEffect,tp,LOCATION_MZONE,0,nil)
	if #rg==0 then return end
	local c=e:GetHandler()
	Duel.BreakEffect()
	local tribute_count=Duel.Release(rg,REASON_EFFECT)
	if tribute_count>0 and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)>0 then
		c:CompleteProcedure()
		if tribute_count<3 then return end
		local desg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
		if #desg==0 then return end
		Duel.BreakEffect()
		if Duel.Destroy(desg,REASON_EFFECT)>0 then
			local opp=1-tp
			Duel.SetLP(opp,Duel.GetLP(opp)/2)
		end
	end
end