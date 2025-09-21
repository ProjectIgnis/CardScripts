--Ｅｍミラー・コンダクター (Anime)
--Performage Mirror Conductor (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum Summon procedure
	Pendulum.AddProcedure(c)
	--The original ATK and DEF of each Special Summoned monster your opponent controls become equal to the lowest value 
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_SET_BASE_ATTACK)
	e1a:SetRange(LOCATION_PZONE)
	e1a:SetTargetRange(0,LOCATION_MZONE)
	e1a:SetTarget(aux.TargetBoolFunction(Card.IsSpecialSummoned))
	e1a:SetValue(s.atkdefval)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e1b)
	--When this card battle an opponent's monster: Target that monster, then switch its ATK/DEF during that damage calculation only
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(s.adswapcon)
	e2:SetTarget(s.adswaptg)
	e2:SetOperation(s.adswapop)
	c:RegisterEffect(e2)
end
function s.atkdefval(e,c)
	if c:GetBaseAttack()<=c:GetBaseDefense() or not c:HasDefense() then
		return c:GetBaseAttack()
	else
		return c:GetBaseDefense()
	end
end
function s.adswapcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsControler(1-tp) and bc:IsRelateToBattle() and bc:IsFaceup() and bc:HasDefense()
end
function s.adswaptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local bc=e:GetHandler():GetBattleTarget()
	if chkc then return chkc==bc end
	if chk==0 then return bc:IsOnField() and bc:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(bc)
end
function s.adswapop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_PHASE|PHASE_DAMAGE_CAL)
		e1:SetValue(tc:GetDefense())
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(tc:GetAttack())
		tc:RegisterEffect(e2)
	end
end
