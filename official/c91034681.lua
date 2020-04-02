--デストーイ・デアデビル
--Frightfur Daredevil
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xc3),aux.FilterBoolFunctionEx(Card.IsSetCard,0xa9))
	--damage after destroying
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(s.damtg1)
	e1:SetOperation(s.damop1)
	c:RegisterEffect(e1)
	--damage after destruction
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.damcon2)
	e2:SetTarget(s.damtg2)
	e2:SetOperation(s.damop2)
	c:RegisterEffect(e2)
end
s.listed_series={0xad,0xc3,0xa9}
s.material_setcode={0xc3,0xa9}
function s.damtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.damop1(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.damcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()~=tp and c:GetOwner()==c:GetPreviousControler() and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousPosition(POS_FACEUP)
end
function s.damfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xad)
end
function s.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local gc=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return gc>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,gc*500)
end
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	local gc=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_GRAVE,0,nil)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Damage(p,gc*500,REASON_EFFECT)
end
