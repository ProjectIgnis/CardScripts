--誘惑の鏡壁
--Eyelluring Mirror Wall
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e0)
	--Gains these effects while you control an "Amazoness" monster or "Harpie Lady"
	--● Face-up monsters your opponent controls are changed to Attack Position and must attack if able
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_SET_POSITION)
	e1a:SetRange(LOCATION_SZONE)
	e1a:SetTargetRange(0,LOCATION_MZONE)
	e1a:SetCondition(s.amzharpiecondition)
	e1a:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_MUST_ATTACK)
	e1b:SetValue(1)
	c:RegisterEffect(e1b)
	--● Once per battle, when an opponent's monster declares an attack: You can halve its ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetAttacker():IsControler(1-tp) and s.amzharpiecondition(e)
	end)
	e2:SetCost(Cost.SoftOncePerBattle(id))
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--Once per turn, during the Standby Phase: You can Set 1 Spell/Trap from your GY or banishment that mentions "Harpie Lady", except "Eyelluring Mirror Wall"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsStandbyPhase()
	end)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	e3:SetHintTiming(TIMING_STANDBY_PHASE)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_HARPIE_LADY,id}
s.listed_series={SET_AMAZONESS}
function s.amzharpiefilter(c)
	return ((c:IsSetCard(SET_AMAZONESS) and c:IsMonster()) or c:IsCode(CARD_HARPIE_LADY)) and c:IsFaceup()
end
function s.amzharpiecondition(e)
	return Duel.IsExistingMatchingCard(s.amzharpiefilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local attacker=Duel.GetAttacker()
	if chk==0 then return attacker:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,at,1,tp,attacker:GetAttack()//2)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local attacker=Duel.GetAttacker()
	if attacker:IsRelateToBattle() and attacker:IsFaceup() then
		--Halve its ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(attacker:GetAttack()//2)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		attacker:RegisterEffect(e1)
	end
end
function s.setfilter(c)
	return c:IsSpellTrap() and c:ListsCode(CARD_HARPIE_LADY) and c:IsFaceup() and c:IsSSetable() and not c:IsCode(id)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end