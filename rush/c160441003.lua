--エターナル・ギャラクティカ・オブリビオン
--Eternal Galactica Oblivion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,false,false,160009002,1,s.matfilter,2)
	-- Mill and gain atk
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.mltg)
	e1:SetOperation(s.mlop)
	c:RegisterEffect(e1)
end
function s.matfilter(c,scard,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT,scard,sumtype,tp) and c:IsRace(RACE_GALAXY,scard,sumtype,tp)
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsRace(RACE_GALAXY) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,5,nil) end
end
function s.mltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.mlop(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local td=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,5,5,nil)
	if #td==0 then return end
	Duel.HintSelection(td,true)
	if Duel.SendtoDeck(td,nil,SEQ_DECKSHUFFLE,REASON_COST)~=5 then return end
	Duel.ShuffleDeck(tp)
	--Effect
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
	local c=e:GetHandler()
	--Cannot be destroyed by opponent's trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3012)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetValue(s.efilter)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	--Gain ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)*300)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
end
function s.efilter(e,te)
	return te:IsTrapEffect() and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end