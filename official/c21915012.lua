--ルイ・キューピット
--Cupid Pitch
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Check the Tuner material's Level
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetLabel(0)
	e0:SetValue(s.valcheck)
	e0:SetOperation(s.matop)
	c:RegisterEffect(e0)
	--Increase or decrease this card's Level
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetLabelObject(e0)
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	--Gains ATK equal to its Level x 400
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(_,c) return c:GetLevel()*400 end)
	c:RegisterEffect(e2)
	--Inflict damage and search 1 Level 8 or lower monster with 600 DEF
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
function s.puretuner(c,sc,tp)
	return not c:IsHasEffect(EFFECT_NONTUNER) and c:IsType(TYPE_TUNER,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp)
end
function s.othertuner(c,sc,tp)
	return (c:IsHasEffect(EFFECT_NONTUNER) and c:IsType(TYPE_TUNER,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp)) or c:IsHasEffect(EFFECT_CAN_BE_TUNER)
end
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	if #mg==0 then return e:SetLabel(0) end
	local tp=e:GetHandlerPlayer()
	local pure_tuner_g=mg:Filter(s.puretuner,nil,c,tp)
	if #pure_tuner_g>0 then
		e:SetLabelObject(nil)
		e:SetLabel(pure_tuner_g:GetFirst():GetSynchroLevel(c))
		return
	end
	local other_tuner_g=mg:Filter(s.othertuner,nil,c,tp)
	if #other_tuner_g>1 then
		e:SetLabelObject(other_tuner_g)
	else
		e:SetLabelObject(nil)
		e:SetLabel(other_tuner_g:GetFirst():GetSynchroLevel(c))
	end
end
function s.matop(e,c)
	local g=e:GetLabelObject()
	if not g then return end
	local tp=e:GetHandlerPlayer()
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,5))
	local tuner=g:Select(tp,1,1,nil):GetFirst()
	Duel.HintSelection(tuner,true)
	e:SetLabel(tuner:GetSynchroLevel(c))
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabelObject():GetLabel()
	if lv==0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		--Increase or decrease this card's Level
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		if opt==0 then
			e1:SetValue(lv)
		else
			e1:SetValue(-lv)
		end
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSynchroSummoned() and c:IsLocation(LOCATION_GRAVE)
		and r&REASON_SYNCHRO>0
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sc=e:GetHandler():GetReasonCard()
	Duel.SetTargetCard(sc)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,sc:GetLevel()*100)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsLevelBelow(8) and c:IsDefense(600) and c:IsAbleToHand()
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local sc=Duel.GetFirstTarget()
	if not (sc:IsRelateToEffect(e) and sc:IsFaceup()) then return end
	if Duel.Damage(1-tp,sc:GetLevel()*100,REASON_EFFECT)>0
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g==0 then return end
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end