--魔鍵憑神－アシュタルトゥ
--Magikey Avatar - Astartu
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	--Inflict damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.damcon)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--Detach 1 material and banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1)
	e2:SetCondition(function(_,tp) return Duel.IsTurnPlayer(1-tp) and Duel.IsMainPhase() end)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
s.listed_series={0x167}
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	if #eg~=1 then return false end
	local bc=eg:GetFirst()
	local rc=bc:GetReasonCard()
	return bc:IsPreviousControler(1-tp) and bc:IsReason(REASON_BATTLE)
		and (rc:IsType(TYPE_NORMAL) or rc:IsSetCard(0x167)) and rc:IsControler(tp)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dam=eg:GetFirst():GetBaseAttack()
	if chk==0 then return dam>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.attrfilter(c)
	return c:IsMonster() and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x167)) and c:IsFaceup()
end
function s.rmfilter(c,ag)
	if not (c:IsFaceup() and c:IsAbleToRemove()) then return false end
	return ag:IsExists(Card.IsAttribute,1,nil,c:GetAttribute())
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ag=Duel.GetMatchingGroup(s.attrfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.rmfilter(chkc,ag) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE,1,nil,ag)
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE,1,1,nil,ag)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:RemoveOverlayCard(tp,1,1,REASON_EFFECT) and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end