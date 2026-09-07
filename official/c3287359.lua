--魔弾の悪魔 カスパール
--Magical Musket Mastermind Caspar
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 monsters, including a LIGHT Fiend monster
	Link.AddProcedure(c,nil,2,2,s.matcheck)
	--Take 2 "Magical Musket" cards from your hand and/or Deck, including a monster, Special Summon 1 of those monsters, and Set the other card to your opponent's field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1:SetTarget(s.spsettg)
	e1:SetOperation(s.spsetop)
	c:RegisterEffect(e1)
	--During either player's turn, you can activate "Magical Musket" Spell/Trap Cards from your hand
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetTargetRange(LOCATION_HAND,0)
	e2a:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_MAGICAL_MUSKET))
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2b)
end
s.listed_series={SET_MAGICAL_MUSKET}
function s.matfilter(c,lc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT,lc,sumtype,tp) and c:IsRace(RACE_FIEND,lc,sumtype,tp)
end
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(s.matfilter,1,nil,lc,sumtype,tp)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsMonster,1,nil) and sg:IsExists(s.spfilter,1,nil,e,tp,sg)
end
function s.spfilter(c,e,tp,sg)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and sg:IsExists(s.setfilter,1,c,e,tp,1-tp)
end
function s.setfilter(c,e,tp,opp)
	return (Duel.GetMZoneCount(opp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,opp)) or c:IsSSetable(false,opp)
end
function s.spsettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetMZoneCount(tp)<=0 then return false end
		local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND|LOCATION_DECK,0,nil,SET_MAGICAL_MUSKET)
		return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spsetop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND|LOCATION_DECK,0,nil,SET_MAGICAL_MUSKET)	
	if #g<2 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,aux.Stringid(id,1))
	if #sg~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local spg=sg:FilterSelect(tp,s.spfilter,1,1,nil,e,tp,sg)
	if #spg>0 and Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)>0 then
		local opp=1-tp
		local setc=(sg-spg):GetFirst()
		local b1=Duel.GetMZoneCount(opp)>0 and setc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,opp)
		local b2=setc:IsSSetable(false,opp)
		local op=nil
		if b1 and b2 then
			op=Duel.SelectEffect(tp,
				{b1,aux.Stringid(id,2)},
				{b2,aux.Stringid(id,3)})
		else
			op=b1 and 1 or 2
		end
		if op==1 then
			Duel.SpecialSummon(setc,0,tp,opp,false,false,POS_FACEDOWN_DEFENSE)
			Duel.ConfirmCards(tp,setc)
		elseif op==2 then
			Duel.SSet(tp,setc,opp)
		end
	end
end
