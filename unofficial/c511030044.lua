--充電機塊セルトパス
--Appliancer Celtopus
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,2)
	--cannot be targeted by attacks
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(s.imcon)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	--cannot be targeted by effects
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--atk up
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	--co-link before destruction check
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_LEAVE_FIELD_P)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.checkcon)
	e4:SetOperation(s.checkop)
	c:RegisterEffect(e4)
	--draw
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id)
	e5:SetCondition(s.drcon)
	e5:SetTarget(s.drtg)
	e5:SetOperation(s.drop)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
s.listed_series={0x57a}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsLevel(1) and c:IsSetCard(0x57a,lc,sumtype,tp)
end
function s.imcon(e)
	return e:GetHandler():IsLinked()
end
function s.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x57a)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local b=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then
		a=Duel.GetAttackTarget()
		b=Duel.GetAttacker()
	end
	local mg=a:GetMutualLinkedGroup()
	local octg=e:GetHandler():GetMutualLinkedGroup()
	return a and a:IsControler(tp) and a:IsLinkMonster() and a~=e:GetHandler() and b and b:IsControler(1-tp)
		and mg:IsContains(e:GetHandler()) and octg:IsContains(a)
		and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local atkct=e:GetHandler():GetMutualLinkedGroupCount()
	local a=Duel.GetAttacker()
	local b=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then 
		a=Duel.GetAttackTarget()
		b=Duel.GetAttacker()
	end
	if a and a:IsRelateToBattle() and a:IsFaceup() and a:IsControler(tp) and atkct>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(atkct*1000)
		a:RegisterEffect(e1)
	end
end
function s.checkfilter(c,e,tp)
	local mg=c:GetMutualLinkedGroup()
	local octg=e:GetHandler():GetMutualLinkedGroup()
	return c:IsSetCard(0x57a) and c:IsControler(tp) and c:IsReason(REASON_DESTROY)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and not (mg:IsContains(e:GetHandler()) and octg:IsContains(c))
end
function s.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.checkfilter,1,e:GetHandler(),e,tp)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(1)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(0)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end