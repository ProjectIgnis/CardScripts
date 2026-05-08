--クリアウィング・ファスト・ドラゴン (Manga)
--Clear Wing Fast Dragon (Manga)
local s,id,alias=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	alias=c:GetOriginalCodeRule()
	--Pendulum procedure
	Pendulum.AddProcedure(c,false)
	--Synchro Summon procedure: 1 Tuner + 1 or more non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Once per turn (Quick Effect): You can target 1 Special Summoned monster your opponent controls; until the end of this turn, its ATK becomes 0, also it has its effects negated.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(alias,1))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.negatkchtg)
	e1:SetOperation(s.negatkchop)
	c:RegisterEffect(e1)
	--If this card in the Monster Zone is destroyed by battle or card effect: You can place this card in your Pendulum Zone.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(alias,2))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.pencon)
	e2:SetTarget(s.pentg)
	e2:SetOperation(s.penop)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsSpecialSummoned() and  (c:IsNegatableMonster() or c:HasNonZeroAttack())
end
function s.negatkchtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,1-tp,LOCATION_MZONE)
end
function s.negatkchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		--Its ATK becomes 0 until the end of this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		--Its effects are negated are until the end of this turn
		tc:NegateEffects(c,RESETS_STANDARD_PHASE_END)	
	end
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r&(REASON_EFFECT|REASON_BATTLE)>0 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
