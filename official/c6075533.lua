--トリシューラの鼓動
--Terror of Trishula
--Scripted by DyXel
local s,id=GetID()
function s.initial_effect(c)
	--Banish based on numbers of "Ice Barrier" Synchro Monster(s)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--Negate effect that targets "Ice Barrier" Synchro Monster(s)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.discon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.distg)
	e2:SetOperation(function(_,_,_,_,ev) Duel.NegateEffect(ev) end)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ICE_BARRIER}
function s.smfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:IsSetCard(SET_ICE_BARRIER) and c:IsType(TYPE_SYNCHRO)
end
function s.bancheck(tp,loc)
	return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,loc,1,nil)
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.smfilter,tp,LOCATION_MZONE,0,nil,tp)
		local dnc=math.min(g:GetClassCount(Card.GetCode),3)
		if dnc==0 then return false end
		local b1=dnc>0 and s.bancheck(tp,LOCATION_ONFIELD)
		local b2=dnc>1 and s.bancheck(tp,LOCATION_GRAVE)
		local b3=dnc>2 and s.bancheck(tp,LOCATION_HAND)
		return b1 or b2 or b3
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_HAND)
end
function s.banlocop(tp,loc,gf)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,loc,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=gf(g,tp,1,1,nil)
		Duel.HintSelection(sg,true)
		return Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
	return 0
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.smfilter,tp,LOCATION_MZONE,0,nil,tp)
	local dnc=g:GetClassCount(Card.GetCode)
	if dnc==0 then return end
	local break_chk=0
	if dnc>0 then
		break_chk=s.banlocop(tp,LOCATION_ONFIELD,Group.Select)
	end
	if dnc>1 then
		if break_chk>0 then Duel.BreakEffect() end
		break_chk=s.banlocop(tp,LOCATION_GRAVE,Group.Select)
	end
	if dnc>2 then
		if break_chk>0 then Duel.BreakEffect() end
		break_chk=s.banlocop(tp,LOCATION_HAND,Group.RandomSelect)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or rp==tp then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg:IsExists(s.smfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end