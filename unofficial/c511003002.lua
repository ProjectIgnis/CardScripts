--Dis-swing Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local fparams={extrafil=s.fextra,extraop=s.extraop,gc=s.fextra}
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate(Fusion.SummonEffTG(fparams),Fusion.SummonEffOP(fparams)))
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s.tokens={[0]=nil,[1]=nil}
		local ge=Effect.CreateEffect(c)
		ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge:SetCode(EVENT_STARTUP)
		ge:SetOperation(s.setup)
		Duel.RegisterEffect(ge,0)
	end)
end
function s.setup(e,tp,eg,ep,ev,re,r,rp)
	s.tokens[0]=Duel.CreateToken(0,946)
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(511002961)
	s.tokens[0]:RegisterEffect(e0)
	s.tokens[1]=Duel.CreateToken(1,946)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(511002961)
	s.tokens[1]:RegisterEffect(e1)
	e:Reset()
end
function s.fextra(e,tp)
	return Group.FromCards(s.tokens[tp])
end
function s.extraop(e,tc,tp,mat)
	mat:RemoveCard(s.tokens[tp])
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	return a:IsControler(1-tp) and a:IsType(TYPE_PENDULUM)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsControlerCanBeChanged() and tg:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tg,1,0,0)
end
function s.activate(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local tgc=Duel.GetFirstTarget()
		if tgc and tgc:IsRelateToEffect(e) and Duel.NegateAttack() then
			Duel.GetControl(tgc,tp)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tgc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
			e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
			e2:SetOperation(s.damop)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tgc:RegisterEffect(e2)
		end
		if fustg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(6205579,0)) then
			Duel.BreakEffect()
			fusop(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetOwner()
	Duel.ChangeBattleDamage(p,ev,false)
	Duel.ChangeBattleDamage(1-p,0,false)
end