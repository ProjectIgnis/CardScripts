--Ａ★スペキュレーション
--Ace★Spades Speculation
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Can only Special Summon "A★Speculation(s)" once per turn
	c:SetSPSummonOnce(id)
	--Fusion Summon procedure
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsAttackAbove,2500),s.matfilter)
	--Special Summon this card from your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Gains ATK equal to the highest original ATK among the opponent's monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e) return e:GetHandler():IsAttackPos() end)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--Cannot be destroyed by battle or card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e) return e:GetHandler():IsDefensePos() end)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
end
s.listed_names={id}
function s.matfilter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsLocation(LOCATION_MZONE) and c:IsDefenseBelow(2500)
end
function s.spcheck(sg,tp)
	return Duel.GetMZoneCount(tp,sg)>0
		and sg:FilterCount(Card.IsAttackPos,nil)==1
		and sg:FilterCount(Card.IsPosition,nil,POS_FACEDOWN_DEFENSE)==1
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,2,false,s.spcheck,nil) end
	local sg=Duel.SelectReleaseGroupCost(tp,nil,2,2,false,s.spcheck,nil)
	Duel.Release(sg,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)
	if #g==0 then return 0 end
	local _,atk=g:GetMaxGroup(Card.GetBaseAttack)
	return atk
end