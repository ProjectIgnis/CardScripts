--ジャンク・ウォリアー／バスター
--Junk Warrior/Assault Mode
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustBeSpecialSummoned()
	--Gains 1000 ATK for each "/Assault Mode" monster you control
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,c) return 1000*Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_ASSAULT_MODE),c:GetControler(),LOCATION_MZONE,0,nil) end)
	c:RegisterEffect(e1)
	--If this card battles a monster, any battle damage it inflicts to your opponent is doubled
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(function(e) return e:GetHandler():GetBattleTarget() end)
	e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e2)
	--Unaffected by your opponent's activated monster effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(function(e,te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated() and te:IsMonsterEffect() end)
	c:RegisterEffect(e3)
	--Return 1 "Junk Warrior" from your GY to the Extra Deck, then you can Special Summon it (this is treated as a Synchro Summon)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetTarget(s.texsptg)
	e4:SetOperation(s.texspop)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_ASSAULT_MODE,CARD_JUNK_WARRIOR}
s.listed_series={SET_ASSAULT_MODE}
s.assault_mode=CARD_JUNK_WARRIOR
function s.texfilter(c)
	return c:IsCode(CARD_JUNK_WARRIOR) and c:IsAbleToExtra()
end
function s.texsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.texfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.texfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.texfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.texspop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_EXTRA) then
		local forcedg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,tc,nil,REASON_SYNCHRO)
		if #forcedg==0 and Duel.GetLocationCountFromEx(tp,tp,nil,tc)>0
			and tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			tc:SetMaterial(nil)
			Duel.BreakEffect()
			if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
				tc:CompleteProcedure()
			end
		end
	end
end