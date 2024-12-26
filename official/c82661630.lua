--登竜華恐巄門
--Ryu-Ge Realm - Dino Domains
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--You can only control 1 "Ryu-Ge Realm - Dino Domains"
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--"Ryu-Ge" monsters you control gain 300 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_RYU_GE))
	e1:SetValue(300)
	c:RegisterEffect(e1)
	--Negate the activation of a monster effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(function(e,tp,eg,ep,ev) Duel.NegateActivation(ev) end)
	--Grant the above effect to "Ryu-Ge" Pendulum Monsters and Level 10 or higher monsters whose original Type is Dinosaur you control
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.efftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--Monsters affected by this card's effect become Effect Monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_ADD_TYPE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.efftg)
	e4:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e4)
end
s.listed_series={SET_RYU_GE}
s.listed_names={id}
function s.efftg(e,c)
	return (c:IsSetCard(SET_RYU_GE) and c:IsType(TYPE_PENDULUM)) or (c:IsLevelAbove(10) and c:IsOriginalRace(RACE_DINOSAUR))
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local trig_loc,trig_typ,trig_atk=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_TYPE,CHAININFO_TRIGGERING_ATTACK)
	return trig_loc&LOCATION_MZONE>0 and trig_typ&TYPE_MONSTER>0 and e:GetHandler():GetAttack()>trig_atk
end
function s.costfilter(c)
	return c:IsSetCard(SET_RYU_GE) and c:IsContinuousSpell() and c:IsFaceup() and c:IsAbleToDeckAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
end