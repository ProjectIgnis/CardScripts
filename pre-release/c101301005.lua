--月光金獅子
--Lunalight Gold Leo
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Lunalight" monster from your Deck to your hand, except "Lunalight Gold Leo", then discard 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.deckthtg)
	e1:SetOperation(s.deckthop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Add 1 "Lunalight" monster sent to the GY to the hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.gythtg)
	e3:SetOperation(s.gythop)
	c:RegisterEffect(e3)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e3:SetLabelObject(g)
	--Keep track of "Lunalight" monsters sent to the GY
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetLabelObject(e3)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_LUNALIGHT}
s.listed_names={id}
function s.deckthfilter(c)
	return c:IsSetCard(SET_LUNALIGHT) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToHand()
end
function s.deckthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.deckthfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.deckthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.deckthfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD,nil)
	end
end
function s.gythfilter(c,e,tp)
	return c:IsSetCard(SET_LUNALIGHT) and c:IsMonster() and c:IsAbleToHand()
		and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.gythfilter,nil,e,tp)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
function s.gythtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetLabelObject():Filter(s.gythfilter,nil,e,tp)
	if chkc then return g:IsContains(chkc) and s.gythfilter(chkc,e,tp) end
	if chk==0 then return #g>0 end
	local tc=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,0)
end
function s.gythop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end