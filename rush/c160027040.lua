--Ｍ・Ｕ・Ｄ
--Master Up-Drake
--scripted by Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion materials: 1 Dragon Type Normal Monster + 2 Dragon Type monsters with 900 DEF
	Fusion.AddProcMixN(c,true,true,s.matfilter1,1,s.matfilter2,2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,nil,nil,SUMMON_TYPE_FUSION,nil,false)
	--If you have "Alpha Burn Drake" in your Graveyard, this card gains 1000 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.alphaburndrakecond)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	--If you have "Alpha Burn Drake" in your Graveyard, your opponent cannot activate Trap Cards when it declares an attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.alphaburndrakecond)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--If you have 3 or more "Alpha Count" in your Graveyard, this card gains an additional 500 ATK
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.alphacountcond)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	--If you have 3 or more "Alpha Count" in your Graveyard, this card inflicts piercing battle damage
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	e4:SetCondition(s.alphacountcond)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_ALPHA_BURN_DRAKE,CARD_ALPHA_COUNT}
function s.matfilter1(c,fc,sumtype,tp)
	return c:IsRace(RACE_DRAGON,fc,sumtype,tp) and c:IsType(TYPE_NORMAL,fc,sumtype,tp) 
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsRace(RACE_DRAGON,fc,sumtype,tp) and c:IsDefense(900)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAbleToDeckOrExtraAsCost),tp,LOCATION_MZONE,0,nil)
end
function s.contactop(g,tp)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.alphaburndrakecond(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,CARD_ALPHA_BURN_DRAKE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Your opponent cannot activate Trap Cards when it declares an attack
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	e1:SetCondition(s.actcon)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsTrap() and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end
function s.alphacountcond(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,3,nil,CARD_ALPHA_COUNT)
end