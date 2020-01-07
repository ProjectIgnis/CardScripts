--Djinn Cycle
--NOTE: Edit out, remove comments when Trigger is already handled by YGoPro Percy
local s,id=GetID()
function s.initial_effect(c)
	--damage
	local e1=Effect.CreateEffect(c)
	--e1:SetCategory(CATEGORY_DAMAGE)
	--e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	--e1:SetDescription(aux.Stringid(11287364,0))
	--e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	--Trigger not allowed on Xyz Material
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(s.damcon)
	--e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(400)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	--local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	--Duel.Damage(p,d,REASON_EFFECT)
	--replacement for Trigger
	local rc=e:GetHandler():GetReasonCard()
	Duel.Hint(HINT_CARD,0,id)
	Duel.Damage(1-rc:GetControler(),400,REASON_EFFECT)
end
