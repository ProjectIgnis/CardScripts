--破滅へのクイック・ドロー
--Destructive Draw
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Register if the player has 0 cards before drawing
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.predraw)
	c:RegisterEffect(e2)
	--Draw 1 additional card during the Draw Phase
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_DRAW)
	e3:SetCondition(s.drwcon)
	e3:SetTarget(s.drwtg)
	e3:SetOperation(s.drwop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--Lose 700 LP during your End Phase
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e4:SetOperation(s.maintenanceop)
	c:RegisterEffect(e4)
	--Take 3000 Damage if this face-up card leaves the field
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_LEAVE_FIELD_P)
	e5:SetOperation(s.checkop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetLabelObject(e5)
	e6:SetOperation(s.damop)
	c:RegisterEffect(e6)
end
function s.predraw(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(ep,LOCATION_HAND,0)==0 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.drwcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RULE and e:GetLabelObject():GetLabel()==1
end
function s.drwtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(ep)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,ep,1)
end
function s.drwop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.maintenanceop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,1-tp,id)
	if Duel.GetLP(tp)>=700 then
		Duel.PayLPCost(tp,700)
	else
		Duel.SetLP(tp,0)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsDisabled() or not c:IsStatus(STATUS_EFFECT_ENABLED) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()==0 then
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.Damage(e:GetHandler():GetPreviousControler(),3000,REASON_EFFECT)
	end
end