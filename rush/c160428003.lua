--超魔輝獣マグナム・オーバーロード［Ｒ］
--Supreme Wildgleam Magnum Overlord [R]
local s,id=GetID()
function s.initial_effect(c)
	-- cannot attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.maxCon)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.aclimit)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
	--register flag
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	c:AddSideMaximumHandler(e2)
end
s.MaximumSide="Right"
function s.maxCon(e)
	--maximum mode check to do
	return e:GetHandler():GetFlagEffect(id)>0 and e:GetHandler():IsMaximumModeCenter()
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsOnField() and rc:IsFaceup() and rc:IsLevelBelow(10)
end
function s.cfilter(c,tp)
	return c:IsLevelAbove(5) and c:IsFaceup() and c:IsSummonPlayer(1-tp)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and e:GetHandler():IsMaximumModeCenter()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
end