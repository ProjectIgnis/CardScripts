--ブリザード・ファルコン
Duel.LoadScript("c419.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.damcon)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not eg:IsContains(c) then return false end
	local val=0
	if c:GetFlagEffect(284)>0 then val=c:GetFlagEffectLabel(284) end
	return c:GetAttack()~=val
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local atk=0
	if c:GetBaseAttack()>=c:GetAttack() then
		atk=c:GetBaseAttack()-c:GetAttack()
	else
		atk=c:GetAttack()-c:GetBaseAttack()
	end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(atk)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local atk=0
	if c:GetBaseAttack()>=c:GetAttack() then
		atk=c:GetBaseAttack()-c:GetAttack()
	else
		atk=c:GetAttack()-c:GetBaseAttack()
	end
	Duel.Damage(p,atk,REASON_EFFECT)
end
