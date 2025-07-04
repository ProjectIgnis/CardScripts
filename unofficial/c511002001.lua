--ＳＮｏ．３９ 希望皇ホープＯＮＥ (Manga)
--Number S39: Utopia Prime (Manga)
Duel.LoadCardScript("c86532744.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 4 monsters OR 1 "Number 39: Utopia" you control
	Xyz.AddProcedure(c,nil,4,3,s.ovfilter,aux.Stringid(id,0))
	--Cannot be destroyed by battle except with "Number" monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(function(e,c) return not c:IsSetCard(SET_NUMBER) end)
	c:RegisterEffect(e2)
	--Banish all monsters your opponent controls, and if you do, inflict damage to your opponent equal to the combined ATK of the banished monsters
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.AND(Cost.Detach(function(e,tp) return e:GetHandler():GetOverlayCount() end),s.lpcost))
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end
s.xyz_number=39
s.listed_names={84013237} --"Number 39: Utopia"
s.listed_series={SET_NUMBER}
function s.ovfilter(c,tp,lc)
	return c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,84013237) and c:IsFaceup()
end
function s.lpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLP(tp)>1 end
	Duel.SetLP(tp,1)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,nil)
	if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0 then
		local sum=Duel.GetOperatedGroup():GetSum(Card.GetAttack)
		Duel.Damage(1-tp,sum,REASON_EFFECT)
	end
end