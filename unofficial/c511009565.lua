--Performage Reversal Dancer
--fixed by MLD
Duel.LoadScript("c419.lua")
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--activate
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(511000377)
	e2:SetRange(LOCATION_PZONE)
	e2:SetLabel(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.con)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(511001441)
	e3:SetLabel(LOCATION_MZONE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(id)
	e4:SetCondition(s.con2)
	e4:SetTarget(s.tg2)
	e4:SetLabel(LOCATION_MZONE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	c:RegisterEffect(e4)
end
s.listed_series={0xc6}
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	if #eg~=1 then return false end
	local val=0
	if ec:GetFlagEffect(284)>0 then val=ec:GetFlagEffectLabel(284) end
	return ec:IsControler(1-tp) and ec:GetAttack()~=val
end
function s.filter(c,label)
	return c:IsFaceup() and (label==LOCATION_PZONE or c:IsSetCard(0xc6))
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local label=e:GetLabel()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,label) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,label) end
	local ec=eg:GetFirst()
	local atk=0
	local val=0
	if ec:GetFlagEffect(284)>0 then val=ec:GetFlagEffectLabel(284) end
	if ec:GetAttack()>val then atk=ec:GetAttack()-val
	else atk=val-ec:GetAttack() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,label)
	Duel.SetTargetParam(atk)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local atk=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	if e:GetLabel()==LOCATION_PZONE and not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	if #eg~=1 then return false end
	local val=0
	if ec:GetFlagEffect(384)>0 then val=ec:GetFlagEffectLabel(384) end
	return ec:IsControler(1-tp) and ec:GetDefense()~=val
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	local ec=eg:GetFirst()
	local def=0
	local val=0
	if ec:GetFlagEffect(384)>0 then val=ec:GetFlagEffectLabel(384) end
	if ec:GetDefense()>val then def=ec:GetDefense()-val
	else def=val-ec:GetDefense() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetTargetParam(def)
end
