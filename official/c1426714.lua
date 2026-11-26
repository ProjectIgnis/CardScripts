--Ｎｏ．４８ シャドー・リッチ
--Number 48: Shadow Lich
local s,id=GetID()
local TOKEN_PHANTOM=id+1
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 3 monsters
	Xyz.AddProcedure(c,nil,3,2)
	--Once per opponent's turn (Quick Effect): You can detach 1 material from this card; Special Summon 1 "Phantom Token" (Fiend-Type/DARK/Level 1/ATK 500/DEF 500)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsTurnPlayer(1-tp)
	end)
	e1:SetCost(Cost.DetachFromSelf(1))
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--While you control a "Phantom Token", your opponent's monsters cannot target this card for attacks
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(function(e)
		return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,TOKEN_PHANTOM),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
	end)
	e2:SetValue(function(e,c)
		return c==e:GetHandler()
	end)
	c:RegisterEffect(e2)
	--Gains 500 ATK for each "Phantom Token" you control
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(function(e,c)
		return 500*Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsCode,TOKEN_PHANTOM),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)
	end)
	c:RegisterEffect(e3)
end
s.xyz_number=48
s.listed_names={TOKEN_PHANTOM}
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_PHANTOM) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_PHANTOM) then
		local token=Duel.CreateToken(tp,TOKEN_PHANTOM)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end