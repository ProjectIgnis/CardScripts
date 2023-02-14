--Japanese name
--Xyz Align
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Change Levels of 2 targets to a declared Level
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,e)
	return c:IsFaceup() and c:HasLevel() and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsControler,1,nil,tp)
end
s.nlvfilter=aux.NOT(Card.IsLevel)
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g1=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil,e)
	local g2=Duel.GetMatchingGroup(s.cfilter,tp,0,LOCATION_MZONE,nil,e)
	if chk==0 then return #g1>0 and (#g1+#g2)>=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceNumber(tp,s.get_declarable_levels(g1,g2))
	local g=(g1+g2):Match(s.nlvfilter,nil,lv)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(sg)
	e:SetLabel(lv,sg:GetFirst():GetRace()|sg:GetNext():GetRace())
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,sg,#sg,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv,races=e:GetLabel()
	local c=e:GetHandler()
	--Cannot Special Summon from the Extra Deck, except monster with the same Type as the targets
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(races) end)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	for tc in g:Iter() do
		--Change level to the declared level
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.get_declarable_levels(g1,g2)
	local opts={}
	for lv=1,12 do
		local ct=g1:FilterCount(s.nlvfilter,nil,lv)
		if ct>1 or (ct>0 and g2:IsExists(s.nlvfilter,1,nil,lv)) then
			table.insert(opts,lv)
		end
	end
	return table.unpack(opts)
end