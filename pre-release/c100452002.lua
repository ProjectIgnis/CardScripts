--蒼の深淵 ディープアイズ・ホワイト・ドラゴン
--Deep-Eyes White Dragon, the Blue Abyss
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--You can discard this card; add 1 Level 1 LIGHT Tuner from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--If a "Blue-Eyes" Ritual Monster(s) and/or "Blue-Eyes White Dragon" is sent to your GY: You can target 1 of them; Special Summon this card from your GY (if it was there when the monster was sent) or hand (even if not), and if you do, its ATK becomes that monster's, also banish it when it leaves the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_GRAVE|LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Keep track of "Blue-Eyes" Ritual Monsters and "Blue-Eyes White Dragon" sent to the GY
	aux.GlobalCheck(s,function()
		s.gygroup=Group.CreateGroup()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={SET_BLUE_EYES}
s.listed_names={CARD_BLUEEYES_W_DRAGON}
function s.thfilter(c)
	return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
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
function s.tgfilter(c,e)
	return ((c:IsSetCard(SET_BLUE_EYES) and c:IsRitualMonster()) or c:IsCode(CARD_BLUEEYES_W_DRAGON))
		and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.tgfilter,nil,e)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		if Duel.GetCurrentChain()==0 then s.gygroup:Clear() end
		s.gygroup:Merge(tg)
		s.gygroup:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		Duel.RaiseEvent(s.gygroup,EVENT_CUSTOM+id,e,0,rp,ep,ev)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=s.gygroup:Filter(s.tgfilter,nil,e):Match(Card.IsControler,nil,tp)
	if chkc then return g:IsContains(chkc) and chkc:IsControler(tp) and s.tgfilter(chkc,e) end
	local c=e:GetHandler()
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local tc=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			--Its ATK becomes that monster's
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(tc:GetAttack())
			e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
			c:RegisterEffect(e1)
		end
		--Banish it when it leaves the field
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3300)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		e2:SetReset(RESET_EVENT|RESETS_REDIRECT)
		c:RegisterEffect(e2,true)
	end
end