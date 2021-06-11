--弩級軍貫－いくら型一番艦
--Carrier Suship - Icefish-Class Auxiliary Dish
--Scripted by DyXel

local ICEFISH_SUSHIP_CODE=101106023 --TODO: Update when released.

local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon.
	Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	--Protection agaisnt opp effects, atk+=base_def.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetCondition(s.contcon)
	e0:SetTarget(s.conttg)
	e0:SetValue(aux.indoval)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.contcon)
	e1:SetTarget(s.conttg)
	e1:SetValue(function(_,c)return c:GetBaseDefense() end)
	c:RegisterEffect(e1)
	--Gains effects based on material.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetLabel(0)
	e2:SetCondition(s.regcon)
	e2:SetTarget(s.regtg)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
s.listed_series={0x168}
s.listed_names={24639891,ICEFISH_SUSHIP_CODE}
function s.contcon(e)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.conttg(e,c)
	return c:IsSetCard(0x168) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()>0
end
function s.sfilter(c)
	return c:IsSetCard(0x168) and c:IsType(TYPE_SPELL|TYPE_TRAP) and c:IsAbleToHand()
end
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local effs=e:GetLabel()
	if chk==0 then
		return ((effs&1)==0 or Duel.IsPlayerCanDraw(tp,1)) and
		       ((effs&(1<<1))==0 or Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil))
	end
	if (effs&(1<<1))~=0 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local effs=e:GetLabel()
	--"Rice Suship": Draw 1 card.
	if (effs&1)~=0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	--"Icefish Suship": Add 1 "Suship" Spell/Trap from your Deck to your hand.
	if (effs&(1<<1))~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local effs=0
	--Check for "Rice Suship".
	if g:IsExists(Card.IsCode,1,nil,24639891) then effs=1 end
	--Check for "Icefish Suship".
	if g:IsExists(Card.IsCode,1,nil,ICEFISH_SUSHIP_CODE) then effs=effs|(1<<1) end
	e:GetLabelObject():SetLabel(effs)
end