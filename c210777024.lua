--Qliphort Codeking
--designed by Natalia, scripted by Naim
function c210777024.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--splimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c210777024.splimit)
	c:RegisterEffect(e2)
	--draw
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(210777024,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c210777024.drcon)
	e3:SetTarget(c210777024.drtg)
	e3:SetOperation(c210777024.drop)
	c:RegisterEffect(e3)
	if not c210777024.global_check then
		c210777024.global_check=true
		c210777024[0]=0
		c210777024[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
		ge1:SetOperation(c210777024.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c210777024.clearop)
		Duel.RegisterEffect(ge2,0)
	end
end
function c210777024.splimit(e,c)
	return not c:IsSetCard(0xaa)
end
function c210777024.checkop(e,tp,eg,ep,ev,re,r,rp)
	local des=eg:GetFirst()
	if des:IsReason(REASON_BATTLE) then
	local rc=des:GetReasonCard()
		if rc and rc:IsSetCard(0xaa) and rc:IsControler(tp) and rc:IsRelateToBattle() then
			local p=rc:GetControler()
			c210777024[p]=c210777024[p]+1
		end
	end
end
function c210777024.clearop(e,tp,eg,ep,ev,re,r,rp)
	c210777024[0]=0
	c210777024[1]=0
end
function c210777024.drcon(e,tp,eg,ep,ev,re,r,rp)
	return c210777024[tp]>0
end
function c210777024.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,c210777024[tp]) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,c210777024[tp])
end
function c210777024.drop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Draw(tp,c210777024[tp],REASON_EFFECT)
end
