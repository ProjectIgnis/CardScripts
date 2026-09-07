--クラッキング・ドラゴン
--Cracking Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be destroyed by battle with a monster with equal or lower Level
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(function(e,c) return c:IsLevelBelow(e:GetHandler():GetLevel()) end)
	c:RegisterEffect(e1)
	--When your opponent Normal or Special Summons exactly 1 monster (and no other monsters are Summoned) while this monster is on the field: You can make that monster lose ATK equal to its Level x 200 (until the end of this turn), and if you do, inflict damage to your opponent equal to the ATK lost by this effect
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,0))
	e2a:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCondition(s.atkcon)
	e2a:SetTarget(s.atktg)
	e2a:SetOperation(s.atkop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	if #eg~=1 or eg:IsContains(e:GetHandler()) then return false end
	local sc=eg:GetFirst()
	return sc:IsSummonPlayer(1-tp) and sc:HasLevel() and sc:IsFaceup()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sc=eg:GetFirst()
	local val=sc:GetLevel()*200
	sc:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,sc,1,tp,val)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,val)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local sc=eg:GetFirst()
	if sc:IsRelateToEffect(e) and sc:IsFaceup() then
		local prev_atk=sc:GetAttack()
		--Make that monster lose ATK equal to its Level x 200 (until the end of this turn)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-sc:GetLevel()*200)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		sc:RegisterEffect(e1)
		Duel.AdjustInstantly(sc)
		local atk_diff=prev_atk-sc:GetAttack()
		if atk_diff>0 then
			Duel.Damage(1-tp,atk_diff,REASON_EFFECT)
		end
	end
end