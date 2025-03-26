--空母軍貫－しらうお型特務艦
--Gunkan Suship Shirauo-class Carrier
--Scripted by DyXel
local CARD_SUSHIP_SHIRAUO=78362751
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon.
	Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	--"Gunkan" monsters cannot be destroyed by opponent's effects
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetCondition(s.contcon)
	e0:SetTarget(s.conttg)
	e0:SetValue(aux.indoval)
	c:RegisterEffect(e0)
	--"Gunkan" monsters gain ATK equal to their original DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.contcon)
	e1:SetTarget(s.conttg)
	e1:SetValue(function(_,c)return c:GetBaseDefense() end)
	c:RegisterEffect(e1)
	--Gains effects based on material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
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
s.listed_series={SET_GUNKAN}
s.listed_names={CARD_SUSHIP_SHARI,CARD_SUSHIP_SHIRAUO}
function s.contcon(e)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.conttg(e,c)
	return c:IsSetCard(SET_GUNKAN) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsXyzSummoned() and e:GetLabel()>0
end
function s.sfilter(c)
	return c:IsSetCard(SET_GUNKAN) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local effs=e:GetLabel()
	if chk==0 then return ((effs&1)>0 and Duel.IsPlayerCanDraw(tp,1))
		or ((effs&2)>0 and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil))
	end
	local cat=0
	if (effs&1)>0 then
		cat=CATEGORY_DRAW
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
	if (effs&2)>0 then
		cat=cat|CATEGORY_TOHAND|CATEGORY_SEARCH
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	e:SetCategory(cat)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local effs=e:GetLabel()
	--"Gukan Suship Shari": Draw 1 card.
	if (effs&1)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	--"Gukan Suship Shirauo": Add 1 "Gunkan" Spell/Trap from your Deck to your hand.
	if (effs&2)>0 then
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
	--Check for "Gukan Suship Shari":
	if g:IsExists(Card.IsCode,1,nil,CARD_SUSHIP_SHARI) then effs=effs|1 end
	--Check for "Gukan Suship Shirauo":
	if g:IsExists(Card.IsCode,1,nil,CARD_SUSHIP_SHIRAUO) then effs=effs|2 end
	e:GetLabelObject():SetLabel(effs)
end