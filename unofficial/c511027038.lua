--魔力無力化の仮面 (Anime)
--Mask of Dispel (Anime)
local s,id=GetID()
function s.initial_effect(c)
	aux.AddPersistentProcedure(c,nil,s.filter,CATEGORY_DISABLE,nil,nil,0x1c0,nil,nil,s.target)
	--Negate the effects of 1 Spell on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(aux.PersistentTargetFilter)
	c:RegisterEffect(e1)
	--Inflict 500 damage to that Spell's controller
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.damcon)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	--When that Spell leaves the field, destroy this card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.descon)
	e3:SetOperation(function(e) Duel.Destroy(e:GetHandler(),REASON_EFFECT) end)
	c:RegisterEffect(e3)
end
function s.filter(c,e)
	return c:IsFaceup() and c:IsSpell() and c~=e:GetHandler()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,tc,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and Duel.IsTurnPlayer(tc:GetControler())
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local p=e:GetHandler():GetFirstCardTarget():GetControler()
	Duel.SetTargetPlayer(p)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,p,500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetFirstCardTarget():GetControler()
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
