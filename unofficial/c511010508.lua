--ブレイブアイズ・ペンデュラム・ドラゴン (Anime)
--Brave-Eyes Pendulum Dragon (Anime)
--Scripted By TheOnePharaoh
--fixed by MLD
Duel.EnableUnofficialProc(PROC_CANNOT_BATTLE_INDES)
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_PENDULUM_DRAGON),aux.FilterBoolFunctionEx(Card.IsRace,RACE_WARRIOR))
	--ATK Change
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_COST)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Always Battle Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BATTLE_INDES)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.tg)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	--Unstoppable Attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UNSTOPPABLE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e3)
end
s.listed_series={SET_PENDULUM_DRAGON}
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetMatchingGroup(Card.HasNonZeroAttack,tp,LOCATION_MZONE,LOCATION_MZONE,c)
	if #tg>0 and Duel.SelectEffectYesNo(tp,c) then
		Duel.Hint(HINT_CARD,0,id)
		local atk=#tg*100
		for tc in aux.Next(tg) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)
		end
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD&(~RESET_TOFIELD))
		c:RegisterEffect(e1)
	end
	Duel.Readjust()
end
function s.tg(e,c)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc==c
end
function s.val(e,re,c)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end