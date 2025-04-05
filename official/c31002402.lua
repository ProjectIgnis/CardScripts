--凶導の福音
--Dogmatikalamity
--scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_EQUAL,filter=aux.FilterBoolFunction(Card.IsSetCard,SET_DOGMATIKA),extrafil=s.extragroup,
								extraop=s.extraop,stage2=s.stage2,forcedselection=s.ritcheck})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DOGMATIKA}
function s.matfilter1(c)
	return c:IsAbleToGrave() and c:IsLevelAbove(1)
end
function s.extragroup(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetMatchingGroup(s.matfilter1,tp,LOCATION_EXTRA,0,nil)
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
	mat:Sub(mat2)
	Duel.ReleaseRitualMaterial(mat)
	Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	Duel.RegisterEffect(e0,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA)
end
function s.ritcheck(e,tp,g,sc)
	local extrac=g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
	local gc=#g
	return extrac==0 or extrac==1 and gc==1,extrac>1 or extrac==1 and gc>1
end