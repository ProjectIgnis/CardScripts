--Ｄ－ＨＥＲＯ ダイヤモンドガイ
--Destiny HERO - Diamond Dude
local s,id=GetID()
function s.initial_effect(c)
	--Excavate the top card of your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:GetType()==TYPE_SPELL then
		Duel.DisableShuffleCheck()
		Duel.SendtoGrave(g,REASON_EFFECT)
		local ae=tc:GetActivateEffect()
		if tc:GetLocation()==LOCATION_GRAVE and ae then
			local e1=Effect.CreateEffect(tc)
			e1:SetDescription(ae:GetDescription())
			e1:SetType(EFFECT_TYPE_IGNITION)
			e1:SetCountLimit(1)
			e1:SetRange(LOCATION_GRAVE)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CONTROL|RESET_PHASE|PHASE_END|RESET_SELF_TURN&~RESET_TOFIELD,2)
			e1:SetCondition(s.spellcon)
			e1:SetTarget(s.spelltg)
			e1:SetOperation(s.spellop)
			tc:RegisterEffect(e1)
		end
	else
		Duel.MoveToDeckBottom(tc)
	end
end
function s.spellcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return e:GetHandler():GetTurnID()~=Duel.GetTurnCount()
end
function s.spelltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ae=e:GetHandler():GetActivateEffect()
	local ftg=ae:GetTarget()
	if chk==0 then
		return not ftg or ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
	if ae:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	else e:SetProperty(0) end
	if ftg then
		ftg(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
function s.spellop(e,tp,eg,ep,ev,re,r,rp)
	local ae=e:GetHandler():GetActivateEffect()
	local fop=ae:GetOperation()
	fop(e,tp,eg,ep,ev,re,r,rp)
end