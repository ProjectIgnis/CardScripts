--Avalanche
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if not eg or #eg~=1 then return false end
	local tc=eg:GetFirst()
	if chkc then return chkc==tc and chkc:GetSummonType()==SUMMON_TYPE_XYZ end
	if chk==0 then return tc and tc:IsOnField() and tc:IsCanBeEffectTarget(e) and tc:GetSummonType()==SUMMON_TYPE_XYZ end
	Duel.SetTargetCard(tc)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_OWNER_RELATE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(s.rcon)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_F)
		e2:SetCategory(CATEGORY_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EVENT_CHAINING)
		e2:SetRange(LOCATION_SZONE)
		e2:SetCondition(s.damcon)
		e2:SetTarget(s.damtg)
		e2:SetOperation(s.damop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e2)
	end
end
function s.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetHandler():GetFirstCardTarget()
	return tg and re and re:GetHandler()==tg
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=e:GetHandler():GetFirstCardTarget()
	if chk==0 then return true end
	Duel.SetTargetPlayer(tg:GetControler())
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tg:GetControler(),500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
