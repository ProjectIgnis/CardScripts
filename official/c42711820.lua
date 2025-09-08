--スクラップ・ウォリアー
--Scrap Warrior
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: "Scrap Synchron" + 1+ non-Tuner monsters
    Synchro.AddProcedure(c,s.tunerfilter,1,1,Synchro.NonTuner(nil),1,99)
	--Add to your hand, or send to the GY, 1 "Junk Synchron" or 1 card that mentions "Junk Warrior" from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetTarget(s.thtgtg)
	e1:SetOperation(s.thtgop)
	c:RegisterEffect(e1)
	--The activated effects of monsters that mention "Junk Warrior", and Synchro Monsters with "Warrior" in their original names, that you control cannot be negated, except "Scrap Warrior"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.effval)
	c:RegisterEffect(e2)
end
s.material={16449363} --"Scrap Synchron"
s.listed_series={SET_WARRIOR}
s.listed_names={16449363,CARD_JUNK_SYNCHRON,CARD_JUNK_WARRIOR,id}
s.material_setcode=SET_SYNCHRON
function s.tunerfilter(c,lc,stype,tp)
    return c:IsSummonCode(lc,stype,tp,16449363) or c:IsHasEffect(20932152)
end
function s.thtgfilter(c)
	return (c:IsCode(CARD_JUNK_SYNCHRON) or c:ListsCode(CARD_JUNK_WARRIOR)) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.thtgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thtgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.thtgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g=Duel.SelectMatchingCard(tp,s.thtgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		aux.ToHandOrElse(g,tp)
	end
end
function s.effval(e,ct)
	local trig_e,trig_p,trig_loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	if not (trig_p==e:GetHandlerPlayer() and (trig_loc&LOCATION_MZONE)>0) then return false end
	local trig_c=trig_e:GetHandler()
	return (trig_c:ListsCode(CARD_JUNK_WARRIOR) or (trig_c:IsSynchroMonster() and trig_c:IsOriginalSetCard(SET_WARRIOR))) and not trig_c:IsCode(id)
end