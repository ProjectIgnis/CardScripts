--女神ヴェルダンディの導き (Anime)
--Goddess Verdande's Guidance (Anime)
--Scripted by Eerie Code and AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Guess top
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(100243009,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	Duel.SetTargetParam(Duel.SelectOption(tp,70,71,72))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(1-tp,0,LOCATION_DECK)<=0
		or not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.DisableShuffleCheck()
	Duel.ConfirmDecktop(1-tp,1)
	local g=Duel.GetDecktopGroup(1-tp,1)
	local tc=g:GetFirst()
	if not tc then return end
	local opt=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if (opt==0 and tc:IsType(TYPE_MONSTER)) then
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,1-tp,POS_FACEDOWN_DEFENSE) then
			Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
		end
	elseif (opt==1 and tc:IsType(TYPE_SPELL)) then
		Duel.SSet(1-tp,tc)
	elseif (opt==2 and tc:IsType(TYPE_TRAP))then
		Duel.SSet(1-tp,tc)
	end
end