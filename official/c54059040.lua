--アイスバーン
--Eisbahn
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Change non-WATER monsters to Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.poscon)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_WATER),tp,LOCATION_MZONE,0,1,nil)
		and eg:IsExists(aux.FaceupFilter(Card.IsAttributeExcept,ATTRIBUTE_WATER),1,nil)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local posg=eg:Filter(aux.FaceupFilter(Card.IsAttributeExcept,ATTRIBUTE_WATER),nil)
	Duel.SetTargetCard(posg)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,posg,#posg,tp,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local posg=Duel.GetTargetCards(e)
	if #posg>0 then
		Duel.ChangePosition(posg,POS_FACEUP_DEFENSE)
	end
end