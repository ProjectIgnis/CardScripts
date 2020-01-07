--邪龍復活の儀式
--Dragon Revival Ritual
--updated by ClaireStanfield
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={99267150}
s.fit_monster={99267150}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=Group.CreateGroup()
	sg:KeepAlive()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC_G)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(0xff)
	e1:SetLabel(0x2f)
	e1:SetLabelObject(sg)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,5)
	e1:SetValue(SUMMON_TYPE_RITUAL)
	c:RegisterEffect(e1)
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,0xff,0,nil,99267150)
	local tc=g:GetFirst()
	while tc do
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_SPSUMMON_PROC_G)
		e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE)
		e2:SetRange(0xff)
		e2:SetLabelObject(e1)
		e2:SetCondition(s.spcon2)
		e2:SetOperation(s.spop2)
		e2:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,5)
		e2:SetValue(SUMMON_TYPE_RITUAL)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
function s.filter(c,e,tp)
	return c:IsCode(99267150) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
end
function s.spcon(e,c,og)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local label=e:GetLabel()
	if label<=0 then return false end
	local i=0x1
	local spchk=0
	while i<0x40 do
		if (label&i)==i then spchk=spchk+1 end
		i=i*2
	end
	if not Duel.GetRitualMaterial(tp):IsExists(Card.IsAttribute,1,nil,label) then return false end
	return spchk>1 or Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c,og)
	Duel.Hint(HINT_CARD,0,120000016)
	local label=e:GetLabel()
	local g=e:GetLabelObject()
	if label<=0 then return false end
	local attchk=0
	local mg=Duel.GetRitualMaterial(tp)
	local i=0x1
	local spchk=0
	while i<0x40 do
		if (label&i)==i then
			spchk=spchk+1
			if mg:IsExists(Card.IsAttribute,1,nil,i) then attchk=attchk+i end
		end
		i=i*2
	end
	repeat
		local att=Duel.AnnounceAttribute(tp,1,attchk)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local mat=mg:FilterSelect(tp,Card.IsAttribute,1,1,nil,att)
		g:Merge(mat)
		mg:Sub(mat)
		Duel.ReleaseRitualMaterial(mat)
		label=label-att
		e:SetLabel(label)
		attchk=attchk-att
		spchk=spchk-1
	until not mg:IsExists(Card.IsAttribute,1,nil,attchk) or attchk==0 or spchk==0 
		or (spchk==1 and not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp))
		or not Duel.SelectYesNo(tp,93)
	if spchk==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		tg:GetFirst():SetMaterial(g)
		og:Merge(tg)
		g:DeleteGroup()
	end
end
function s.spcon2(e,c,og)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local label=e:GetLabelObject():GetLabel()
	if label<=0 then return false end
	local i=0x1
	local spchk=0
	while i<0x40 do
		if (label&i)==i then spchk=spchk+1 end
		i=i*2
	end
	if not Duel.GetRitualMaterial(tp):IsExists(Card.IsAttribute,1,nil,label) then return false end
	return spchk>1 or Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp,c,og)
	Duel.Hint(HINT_CARD,0,120000016)
	local label=e:GetLabelObject():GetLabel()
	local g=e:GetLabelObject():GetLabelObject()
	if label<=0 then return false end
	local attchk=0
	local mg=Duel.GetRitualMaterial(tp)
	local i=0x1
	local spchk=0
	while i<0x40 do
		if (label&i)==i then
			spchk=spchk+1
			if mg:IsExists(Card.IsAttribute,1,nil,i) then attchk=attchk+i end
		end
		i=i*2
	end
	repeat
		local att=Duel.AnnounceAttribute(tp,1,attchk)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local mat=mg:FilterSelect(tp,Card.IsAttribute,1,1,nil,att)
		g:Merge(mat)
		mg:Sub(mat)
		Duel.ReleaseRitualMaterial(mat)
		label=label-att
		e:GetLabelObject():SetLabel(label)
		attchk=attchk-att
		spchk=spchk-1
	until not mg:IsExists(Card.IsAttribute,1,nil,attchk) or attchk==0 or spchk==0 
		or (spchk==1 and not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp))
		or not Duel.SelectYesNo(tp,93)
	if spchk==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		tg:GetFirst():SetMaterial(g)
		og:Merge(tg)
		g:DeleteGroup()
	end
end
