--人造人間－サイコ・エナジー・ショッカー
--Jinzo - Energy Shocker
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--This card's name becomes "Jinzo" while in the field or GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e1:SetValue(CARD_JINZO)
	c:RegisterEffect(e1)
	--If this card is Normal or Special Summoned: You can destroy as many Traps your opponent controls as possible (if a card is Set, reveal it), then this card gains 300 ATK for each card destroyed this way
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,0))
	e2a:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetCountLimit(1,id)
	e2a:SetTarget(s.destg)
	e2a:SetOperation(s.desop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
	--Your opponent cannot activate Trap Cards or effects while you have another monster in your field or GY that mentions "Dark Time Wizard"
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.cannotactcon)
	e3:SetValue(function(e,re,tp) return re:IsTrapEffect() end)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_JINZO,CARD_DARK_TIME_WIZARD}
function s.desfilter(c)
	return (c:IsTrap() and c:IsFaceup()) or (c:IsSpellTrap() and c:IsFacedown())
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsTrap),tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		local fdg=g:Filter(Card.IsFacedown,nil)
		if #fdg>0 then Duel.ConfirmCards(tp,fdg) end
		local traps=g:Filter(Card.IsTrap,nil)
		if #traps==0 then return end
		local c=e:GetHandler()
		local destroy_count=Duel.Destroy(traps,REASON_EFFECT)
		if destroy_count>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.BreakEffect()
			--This card gains 300 ATK for each card destroyed this way
			c:UpdateAttack(300*destroy_count)
		end
	end
end
function s.cannotactconfilter(c)
	return c:ListsCode(CARD_DARK_TIME_WIZARD) and c:IsMonster() and c:IsFaceup()
end
function s.cannotactcon(e)
	return Duel.IsExistingMatchingCard(s.cannotactconfilter,e:GetHandlerPlayer(),LOCATION_MZONE|LOCATION_GRAVE,0,1,e:GetHandler())
end