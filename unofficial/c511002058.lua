--No.52 ダイヤモンド・クラブ・キング (Manga)
--Number 52: Diamond Crab King (Manga)
Duel.LoadCardScript("c7194917.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,2)
	--Cannot be destroyed by battle, except with "Number" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e1)
	--You can detach 1 Xyz Material from this card; you can make this card lose DEF in multiples of 100, and if you do, this card gains ATK equal to the same amount
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95100120,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetTarget(s.atkdefchtg)
	e2:SetOperation(s.atkdefchop)
	c:RegisterEffect(e2)
	--During your End Phase: Change this card to face-up Defense Position.
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_NUMBER}
s.xyz_number=52
function s.atkdefchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():HasNonZeroDefense() end
end
function s.atkdefchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local maxc=c:GetDefense()
	maxc=math.floor(maxc/100)*100
	local t={}
	for i=1,maxc/100 do
		t[i]=i*100
	end
	local val=Duel.AnnounceNumber(tp,table.unpack(t))
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		--This card loses DEF in multiples of 100
		c:UpdateDefense(-val,RESETS_STANDARD_PHASE_END)
		--This card gains an equal amount of ATK
		c:UpdateAttack(val,RESETS_STANDARD_PHASE_END)
		--If this card attacks a Defense Position monster, inflict piercing damage
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
