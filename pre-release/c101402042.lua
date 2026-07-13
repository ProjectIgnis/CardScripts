--Ｎｏ．１０４ 仮面魔踏士シャイニングＶ
--Number 104: Masquerade Vain
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,3)
	--Once per turn: You can detach 1 material from this card; add 1 "Barian's" Spell/Trap from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.DetachFromSelf(1))
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--A monster that was Xyz Summoned using this card on the field as material gains this effect
	--● If it is Xyz Summoned: Activate this effect; your opponent can banish 4 monsters with different Attributes and 1 Spell from their Deck. If they do not, you banish the top 10 cards of their Deck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return r==REASON_XYZ
	end)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_BARIANS}
s.xyz_number=104
function s.thfilter(c)
	return c:IsSetCard(SET_BARIANS) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then 
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	--● If it is Xyz Summoned: Activate this effect; your opponent can banish 4 monsters with different Attributes and 1 Spell from their Deck. If they do not, you banish the top 10 cards of their Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		return c:IsXyzSummoned() and eg:IsContains(c)
	end)
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
function s.rescon(sg,e,tp,mg)
	return #sg==5 and sg:GetClassCount(Card.GetAttribute)==5,sg:FilterCount(Card.IsSpell,nil)~=1
end
function s.banfilter(c)
	return (c:IsMonster() or c:IsSpell()) and c:IsAbleToRemove()
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local opp=1-tp
	local g=Duel.GetMatchingGroup(s.banfilter,tp,0,LOCATION_DECK,nil)
	if g:IsExists(Card.IsSpell,1,nil) and g:GetClassCount(Card.GetAttribute)>4 and Duel.SelectYesNo(opp,aux.Stringid(id,2)) then
		local sg=aux.SelectUnselectGroup(g,e,opp,5,5,s.rescon,1,opp,HINTMSG_REMOVE)
		if #sg==5 then
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT,nil,opp)
		end
	else
		local dg=Duel.GetDecktopGroup(opp,10)
		Duel.DisableShuffleCheck()
		Duel.Remove(dg,POS_FACEUP,REASON_EFFECT)
	end
end