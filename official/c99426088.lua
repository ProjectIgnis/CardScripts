--魔鍵－マフテア
--Magikey Maftea
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Fusion/Ritual summon
	local fparams={fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_MAGIKEY),extrafil=s.fextra,extratg=s.extratg}
	local rparams={filter=aux.FilterBoolFunction(Card.IsSetCard,SET_MAGIKEY),lvtype=RITPROC_GREATER,extrafil=s.rextra,extraop=s.extraop,forcedselection=s.rcheck,extratg=s.extratg}
	local fustg,fusop,rittg,ritop=Fusion.SummonEffTG(fparams),Fusion.SummonEffOP(fparams),Ritual.Target(rparams),Ritual.Operation(rparams)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target(fustg,rittg))
	e1:SetOperation(s.operation(fustg,fusop,rittg,ritop))
	c:RegisterEffect(e1)
end
s.listed_series={SET_MAGIKEY}
function s.fextra(e,tp,mg)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_NORMAL),tp,LOCATION_MZONE,0,1,nil) then
		local sg=Duel.GetMatchingGroup(s.fexfilter,tp,LOCATION_DECK,0,nil)
		if #sg>0 then
			return sg,s.fcheck
		end
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.fexfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.rcheck(e,tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.rextra(e,tp,mg)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_NORMAL),tp,LOCATION_MZONE,0,1,nil) then
		local sg=Duel.GetMatchingGroup(s.fexfilter,tp,LOCATION_DECK,0,nil)
		if #sg>0 then
			return sg
		end
	end
	return nil
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_DECK)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.target(fustg,rittg)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return fustg(e,tp,eg,ep,ev,re,r,rp,chk) or rittg(e,tp,eg,ep,ev,re,r,rp,chk) end
	end
end
function s.operation(fustg,fusop,rittg,ritop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local fus=fustg(e,tp,eg,ep,ev,re,r,rp,0)
		local rit=rittg(e,tp,eg,ep,ev,re,r,rp,0)
		if fus or rit then
			local sel={}
			if fus then table.insert(sel,aux.Stringid(id,0)) end
			if rit then table.insert(sel,aux.Stringid(id,1)) end
			local res=Duel.SelectOption(tp,table.unpack(sel))
			if res==0 and fus then
				fusop(e,tp,eg,ep,ev,re,r,rp)
			else
				ritop(e,tp,eg,ep,ev,re,r,rp)
			end
		end
	end
end