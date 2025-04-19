--アストログラフ・マジシャン (Anime)
--Astrograph Sorcerer (Anime)
--Rescripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Special Summon Supreme King Z-Arc
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.zarccost)
	e2:SetTarget(s.zarctg)
	e2:SetOperation(s.zarcop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_ZARC,41209827,82044279,16195942,16178681}
local ZARC_LOC=LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_EXTRA|LOCATION_DECK
function s.spcfilter(c,e,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and ((c:IsCanBeEffectTarget(e) and (c:IsLocation(LOCATION_SZONE|LOCATION_GRAVE|LOCATION_MZONE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))) or (c:IsLocation(LOCATION_HAND|LOCATION_DECK) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup())))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.spcfilter,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,1,tp,false,false) end
	local g=eg:Filter(s.spcfilter,nil,e,tp)
	Duel.SetTargetCard(g)
	if g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)>0 then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g:Filter(Card.IsLocation,nil,LOCATION_GRAVE),g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE),tp,LOCATION_GRAVE)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_HAND)
end
function s.spcfilterchk(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and (c:IsLocation(LOCATION_SZONE|LOCATION_GRAVE|LOCATION_MZONE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup())) or (c:IsLocation(LOCATION_HAND|LOCATION_DECK) or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceup())) and not Duel.GetFieldCard(tp,c:GetPreviousLocation(),c:GetPreviousSequence())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetTargetCards(e)
	local freezone=true
	for tc in g:Iter() do
		if Duel.GetFieldCard(tp,tc:GetPreviousLocation(),tc:GetPreviousSequence()) then freezone=false end
	end
	if Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)>0 and #g>0 and freezone==true and Duel.SelectEffectYesNo(tp,c) then
		g:KeepAlive()
		--spsummon
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_CUSTOM+id)
		e1:SetLabelObject(g)
		e1:SetTarget(s.rettg)
		e1:SetOperation(s.retop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,r,tp,tp,0)
	end
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=e:GetLabelObject()
	Duel.SetTargetCard(g)
	g:DeleteGroup()
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(s.spcfilterchk,nil,tp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BECOME_LINKED_ZONE)
	e1:SetValue(0xffffff)
	Duel.RegisterEffect(e1,tp)
	for tc in aux.Next(g) do
		if tc:IsPreviousLocation(LOCATION_PZONE) then
			local seq=0
			if tc:GetPreviousSequence()==7 or tc:GetPreviousSequence()==4 then seq=1 end
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,tc:GetPreviousPosition(),true,(1<<seq))
		else
			Duel.MoveToField(tc,tp,tp,tc:GetPreviousLocation(),tc:GetPreviousPosition(),true,(1<<tc:GetPreviousSequence()))
		end
	end
	e1:Reset()
end
function s.zarccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.zarcspfilter(c,e,tp,sg)
	return c:IsCode(CARD_ZARC) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,sg+e:GetHandler(),c)>0
end
function s.chk(c,sg,g,code,...)
	if not c:IsCode(code) then return false end
	local res
	if ... then
		g:AddCard(c)
		res=sg:IsExists(s.chk,1,g,sg,g,...)
		g:RemoveCard(c)
	else
		res=true
	end
	return res
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(s.chk,1,nil,sg,Group.CreateGroup(),41209827,82044279,16195942,16178681) and Duel.GetLocationCountFromEx(tp,tp,sg+e:GetHandler(),TYPE_FUSION)>0
end
function s.zarctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,ZARC_LOC,0,nil)
	local g1=rg:Filter(Card.IsCode,nil,41209827)
	local g2=rg:Filter(Card.IsCode,nil,82044279)
	local g3=rg:Filter(Card.IsCode,nil,16195942)
	local g4=rg:Filter(Card.IsCode,nil,16178681)
	local g=g1:Clone()
	g:Merge(g2)
	g:Merge(g3)
	g:Merge(g4)
	if chk==0 then return #g1>0 and #g2>0 and #g3>0 and #g4>0 and Duel.IsExistingMatchingCard(s.zarcspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) and aux.SelectUnselectGroup(g,e,tp,4,4,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,4,tp,ZARC_LOC)
end
function s.zarcop(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,ZARC_LOC,0,nil):Filter(Card.IsCode,nil,41209827,82044279,16195942,16178681)
	local g=aux.SelectUnselectGroup(rg,e,tp,4,4,s.rescon,1,tp,HINTMSG_REMOVE)
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>=4 and g:FilterCount(aux.AND(Card.IsFaceup,Card.IsLocation),nil,LOCATION_REMOVED)>=4 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.zarcspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,g):GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and tc:IsOriginalCode(511009441) then
			tc:CompleteProcedure()
		end
	end
	g:DeleteGroup()
end