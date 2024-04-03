--ウォークライ・ディグニティ
--War Rock Dignity
--Scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(function(e,tp,eg,ep,ev) Duel.NegateEffect(ev) end)
	c:RegisterEffect(e1)
end
s.listed_series={SET_WAR_ROCK}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_WAR_ROCK),tp,LOCATION_MZONE,0,1,nil) and Duel.IsChainDisablable(ev)) then return false end
	local trig_loc,trig_contr=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_CONTROLER)
	return (re:IsMonsterEffect() and trig_loc==LOCATION_MZONE and trig_contr==1-tp)
		or (Duel.IsBattlePhase() and rp==1-tp and (re:IsMonsterEffect() or re:IsHasType(EFFECT_TYPE_ACTIVATE)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
end