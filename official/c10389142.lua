--Ｎｏ．４２ スターシップ・ギャラクシー・トマホーク
--Number 42: Galaxy Tomahawk
local s,id=GetID()
local TOKEN_BATTLE_EAGLE=id+1
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 7 monsters
	Xyz.AddProcedure(c,nil,7,2)
	--Special Summon as many "Battle Eagle Tokens" (Machine-Type/WIND/Level 6/ATK 2000/DEF 0) as possible, but destroy them during the End Phase of this turn, also your opponent takes no further battle damage this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.DetachFromSelf(2))
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.xyz_number=42
s.listed_names={TOKEN_BATTLE_EAGLE}
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_BATTLE_EAGLE,0,TYPES_TOKEN,2000,0,6,RACE_MACHINE,ATTRIBUTE_WIND) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_BATTLE_EAGLE,0,TYPES_TOKEN,2000,0,6,RACE_MACHINE,ATTRIBUTE_WIND) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local sg=Group.CreateGroup()
	for i=1,ft do
		local token=Duel.CreateToken(tp,TOKEN_BATTLE_EAGLE)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		sg:AddCard(token)
	end
	--Destroy them during the End Phase of this turn
	aux.DelayedOperation(sg,PHASE_END,id,e,tp,function(ag) Duel.Destroy(ag,REASON_EFFECT) end,nil,nil,1,aux.Stringid(id,1))
	Duel.SpecialSummonComplete()
	--Your opponent takes no further battle damage this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
