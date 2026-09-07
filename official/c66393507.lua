--エクスクローラー・ニューロゴス
--X-Krawler Neurogos
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 Insect monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_INSECT),2,2)
	--"Krawler" monsters this card points to cannot be destroyed by battle
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1a:SetTarget(function(e,c) return c:IsSetCard(SET_KRAWLER) and e:GetHandler():GetLinkedGroup():IsContains(c) end)
	e1a:SetValue(1)
	c:RegisterEffect(e1a)
	--Gain 300 ATK/DEF
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_UPDATE_ATTACK)
	e1b:SetValue(300)
	c:RegisterEffect(e1b)
	local e1c=e1b:Clone()
	e1c:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1c)
	--If they battle your opponent's monster, any battle damage they inflict to your opponent is doubled
	local e1d=e1a:Clone()
	e1d:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1d:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1d:SetTarget(s.doubledamtg)
	e1d:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1d)
	--Special Summon 2 "Krawler" monsters with different names from your GY in face-down Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_KRAWLER}
function s.doubledamtg(e,c)
	local bc=c:GetBattleTarget()
	return c:IsSetCard(SET_KRAWLER) and bc and bc:IsControler(1-e:GetHandlerPlayer()) and e:GetHandler():GetLinkedGroup():IsContains(c)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
		and c:IsPreviousPosition(POS_FACEUP)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_KRAWLER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and g:GetClassCount(Card.GetCode)>=2 end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,2,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 or (#tg>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>0 and ft<#tg then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		tg=tg:Select(tp,ft,ft,nil)
	end
	if #tg>0 and Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		Duel.ConfirmCards(1-tp,tg)
	end
end