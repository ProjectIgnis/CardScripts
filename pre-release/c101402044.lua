--ＣＸ 冀望皇龍カオス・バリアン
--CXyz Chaos Barian Hope Dragon
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3+ Level 7 monsters OR 1 "Number C" monster you control with a number between "101" and "107" in its name
	Xyz.AddProcedure(c,nil,7,3,s.ovfilter,aux.Stringid(id,0),Xyz.InfiniteMats)
	--Gains 1000 ATK for each material attached to it
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,c)
		return c:GetOverlayCount()*1000
	end)
	c:RegisterEffect(e1)
	--While this card has a "Number C" monster as material, your opponent cannot add cards from the Deck to the hand, except by drawing them
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(function(e)
		return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,SET_NUMBER_C)
	end)
	e2:SetTarget(function(e,c,rp,re)
		return c:IsLocation(LOCATION_DECK)
	end)
	c:RegisterEffect(e2)
	--Once per turn: You can detach 1 material from this card; attach the top 2 cards of your opponent's Deck to this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(Cost.DetachFromSelf(1))
	e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsXyzMonster() and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>=2 end
	end)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local g=Duel.GetDecktopGroup(1-tp,2)
		if c:IsRelateToEffect(e) and #g==2 then
			Duel.DisableShuffleCheck()
			Duel.Overlay(c,g)
		end
	end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_NUMBER_C}
function s.ovfilter(c,tp,lc)
	if c:IsFacedown() or not c:IsSetCard(SET_NUMBER_C,lc,SUMMON_TYPE_XYZ,tp) then return false end
	local class=c:GetMetatable(true)
	if class==nil then return false end
	local no=class.xyz_number
	return no and no>=101 and no<=107 
end