--Scripted by Eerie Code
--Performapal Odd-Eyes Unicorn
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--Increase ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
end
s.listed_series={0x99,0x9f}

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at:IsControler(tp) and at:IsSetCard(0x99)
end
function s.atkfil(c)
	return c:IsFaceup() and c:IsSetCard(0x9f) and c:GetAttack()>0
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttacker():IsCanBeEffectTarget(e) and Duel.IsExistingMatchingCard(s.atkfil,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetTargetCard(Group.FromCards(Duel.GetAttacker()))
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,Duel.GetAttacker(),1,0,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetFirstTarget()
	local g=Duel.SelectMatchingCard(tp,s.atkfil,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		local tg=g:GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCategory(CATEGORY_ATKCHANGE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tg:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		at:RegisterEffect(e1)
	end
end

function s.atkfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x99) or c:IsSetCard(0x9f))
end
function s.atkval(e,c)
	if s.atkfilter(c) then
		return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_MZONE,0,nil)*100
	else return 0 end	
end