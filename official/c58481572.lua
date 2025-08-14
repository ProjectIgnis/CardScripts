--Ｍ・ＨＥＲＯ ダーク・ロウ
--Masked HERO Dark Law
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Must be Special Summoned by "Mask Change"
	c:AddCannotBeSpecialSummoned()
	--Any card sent to your opponent's GY is banished instead
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	e1:SetTarget(function(e,c) local tp=e:GetHandlerPlayer() return not c:IsOwner(tp) and Duel.IsPlayerCanRemove(tp,c) end)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	--Banish 1 random card from your opponent's hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.handrmcon)
	e2:SetTarget(s.handrmtg)
	e2:SetOperation(s.handrmop)
	c:RegisterEffect(e2)
end
function s.handrmconfilter(c,opp)
	return c:IsPreviousControler(opp) and c:IsPreviousLocation(LOCATION_DECK) and c:IsControler(opp)
end
function s.handrmcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsDrawPhase() and eg:IsExists(s.handrmconfilter,1,nil,1-tp)
end
function s.handrmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end
function s.handrmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil):RandomSelect(tp,1)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end