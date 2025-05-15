--落消しのパズロミノ
--Puzzlomino, the Drop-n-Deleter
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 monsters with different Levels
	Link.AddProcedure(c,s.mfilter,2,nil,s.matcheck)
	--Change the Level of a monster(s) Special Summoned to a zone this card points to
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.lvcon)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	--Destroy 2 monsters (1 from each field) with the same level
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.mfilter(c)
	return c:HasLevel() and not c:IsLevel(0)
end
function s.matcheck(g,lc,sumtype,tp)
	return g:GetClassCount(Card.GetLevel)==#g
end
function s.cfilter(c,tp,lg)
	return c:IsLevelAbove(1) and c:IsFaceup() and c:IsControler(tp) and lg:IsContains(c)
end
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(s.cfilter,1,nil,tp,lg)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local lg=e:GetHandler():GetLinkedGroup()
	local g=eg:Filter(s.cfilter,nil,tp,lg)
	local lv
	if #g==1 then
		lv=g:GetFirst():GetLevel()
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	e:SetLabel(Duel.AnnounceLevel(tp,1,8,lv))
	e:SetLabelObject(g)
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,g,#g,0,e:GetLabel())
end
function s.opfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=e:GetHandler():GetLinkedGroup()
	local g=eg:Filter(s.cfilter,nil,tp,lg)
	--Their levels become the declared Level
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.desfilter(c,e)
	return c:IsFaceup() and c:HasLevel() and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetControler)==2 and sg:GetClassCount(Card.GetLevel)==1
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.desfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local dg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_DESTROY)
	Duel.SetTargetCard(dg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetTargetCards(e)
	if #dg>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
