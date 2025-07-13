--Ｎｏ．１０５ ＢＫ 流星のセスタス
--Number 105: Battlin' Boxer Star Cestus
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,3)
	--Negate the effects of that opponent's monster while it is face-up until the end of this turn, that monster you control cannot be destroyed by that battle, also your opponent takes any battle damage you would have taken from that battle
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_ATTACK|TIMING_BATTLE_PHASE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(s.discon)
	e1:SetCost(Cost.DetachFromSelf(1))
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
end
s.xyz_number=105
s.listed_series={SET_BATTLIN_BOXER}
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local bc1,bc2=Duel.GetBattleMonster(tp)
	return bc1 and bc2 and bc1:IsSetCard(SET_BATTLIN_BOXER) and bc1:IsFaceup()
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc1,bc2=Duel.GetBattleMonster(tp)
	if bc2:IsRelateToBattle() and bc2:IsNegatableMonster() then
		--Negate the effects of that opponent's monster while it is face-up until the end of this turn
		bc2:NegateEffects(c,RESETS_STANDARD_PHASE_END)
	end
	if bc1:IsRelateToBattle() then
		--That monster you control cannot be destroyed by that battle
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3000)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
		bc1:RegisterEffect(e1,true)
		--Also your opponent takes any battle damage you would have taken from that battle
		local e2=e1:Clone()
		e2:SetDescription(3112)
		e2:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
		bc1:RegisterEffect(e2,true)
	end
end
